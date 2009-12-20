/*
*    The contents of this file are subject to the Mozilla Public License
*    Version 1.1 (the "License"); you may not use this file except in
*    compliance with the License. You may obtain a copy of the License at
*    http://www.mozilla.org/MPL/
*    
*    Software distributed under the License is distributed on an "AS IS"
*    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*    License for the specific language governing rights and limitations
*    under the License.
*    
*    The Original Code is Phoenix.
*    The Initial Developers of the Original Code are 13th and Jyrno42.
*/

/*
*    This File: object_Rotation.inc
*    Purpose: Add RotateObject function to Phoenix.
*    Author: Jyrno42
*/



/*
*    DEFINES
*/

#define ROTATION_TICKS 	50
#define MAX_ROTATE 		50
#define CLOSETOEND 		0.5

/*
*    GLOBALS
*/

enum rotateInf
{
	bool: xMin,
	bool: yMin,
	bool: zMin,
	bool: skipX,
	bool: skipY,
	bool: skipZ,
	Float: curRX,
	Float: curRY,
	Float: curRZ,
	Float: endRX,
	Float: endRY,
	Float: endRZ,
	Float: stepX,
	Float: stepY,
	Float: stepZ,
	rotObj,
	rotTimer
};
new gRotatingObj[MAX_ROTATE][rotateInf];
Itter_Create(RotateObject, MAX_ROTATE);

/*
*    FORWARDS
*/

forward RotateObject(objectId, Float: rotX, Float: rotY, Float: rotZ);
forward DoRotateObject(rotObject);

/*
*    PUBLICS
*/

public RotateObject(objectId, Float: rotX, Float: rotY, Float: rotZ)
{
	new freeId = Itter_Free(RotateObject);
	if(freeId == -1) return 1;

	gRotatingObj[freeId][endRX] = rotX;
	gRotatingObj[freeId][endRY] = rotY;
	gRotatingObj[freeId][endRZ] = rotZ;

	GetObjectRot(objectId, gRotatingObj[freeId][curRX], gRotatingObj[freeId][curRY], gRotatingObj[freeId][curRZ]);
	
	if(gRotatingObj[freeId][curRX] > rotX) gRotatingObj[freeId][xMin] = true;
	if(gRotatingObj[freeId][curRY] > rotY) gRotatingObj[freeId][yMin] = true;
	if(gRotatingObj[freeId][curRZ] > rotZ) gRotatingObj[freeId][zMin] = true;
	
	new Float: dX, Float: dY, Float: dZ; // rotating distances
	
	dX = gRotatingObj[freeId][curRX]-rotX;
	dY = gRotatingObj[freeId][curRY]-rotY;
	dZ = gRotatingObj[freeId][curRZ]-rotZ;
	
	if(dX < dY && dX < dZ) // dX is smallest
	{
		gRotatingObj[freeId][stepX] = 1.0;
		gRotatingObj[freeId][stepY] = (dY/dX);
		gRotatingObj[freeId][stepZ] = (dZ/dX);
	}
	else if(dY < dX && dY < dZ) // dY is smallest
	{
		gRotatingObj[freeId][stepX] = (dX/dY);
		gRotatingObj[freeId][stepY] = 1.0;
		gRotatingObj[freeId][stepZ] = (dZ/dY);
	}
	else if(dZ < dX && dZ < dY) // dZ is smallest
	{
		gRotatingObj[freeId][stepX] = (dX/dZ);
		gRotatingObj[freeId][stepY] = (dY/dZ);
		gRotatingObj[freeId][stepZ] = 1.0;
	}
	
	gRotatingObj[freeId][rotObj] = objectId;
	Itter_Add(RotateObject, freeId);
	
	gRotatingObj[freeId][rotTimer] = SetTimerEx("DoRotateObject", ROTATION_TICKS, 1, "i", freeId);
	return 0;
}

public DoRotateObject(rotObject)
{
	gRotatingObj[rotObject][curRX] += gRotatingObj[rotObject][stepX];
	gRotatingObj[rotObject][curRY] += gRotatingObj[rotObject][stepY];
	gRotatingObj[rotObject][curRZ] += gRotatingObj[rotObject][stepZ];
	SetObjectRot(gRotatingObj[rotObject][rotObj], gRotatingObj[rotObject][curRX], gRotatingObj[rotObject][curRY], gRotatingObj[rotObject][curRZ]);
	
	new bool: end = false;
	
	// Is it done yet?
	if(!gRotatingObj[rotObject][xMin] && (gRotatingObj[rotObject][endRX]-gRotatingObj[rotObject][curRX]) < CLOSETOEND) end = true;
	else if(gRotatingObj[rotObject][xMin] && (gRotatingObj[rotObject][curRX]-gRotatingObj[rotObject][endRX]) < CLOSETOEND) end = true;	
	if(!gRotatingObj[rotObject][yMin] && (gRotatingObj[rotObject][endRY]-gRotatingObj[rotObject][curRY]) < CLOSETOEND) end = true;
	else if(gRotatingObj[rotObject][yMin] && (gRotatingObj[rotObject][curRY]-gRotatingObj[rotObject][endRY]) < CLOSETOEND) end = true;
	if(!gRotatingObj[rotObject][zMin] && (gRotatingObj[rotObject][endRZ]-gRotatingObj[rotObject][curRZ]) < CLOSETOEND) end = true;
	else if(gRotatingObj[rotObject][zMin] && (gRotatingObj[rotObject][curRZ]-gRotatingObj[rotObject][endRZ]) < CLOSETOEND) end = true;
	
	if(end)
	{
		KillTimer(gRotatingObj[rotObject][rotTimer]);
		Itter_Remove(RotateObject, rotObject);
	}	
}
