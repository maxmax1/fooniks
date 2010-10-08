function uploadFiles( files )

	for k, v in pairs( files ) do
		
		local fileName = "";
		local fileData = "";
		
		for k2, v2 in pairs( v ) do
		
			if( k2 == "file" ) then
			
				fileData = v2;
			
			elseif( k2 == "filename" ) then
		
				fileName = v2;
			
			end
		
		end
		
		local file = fileCreate( fileName );
		fileWrite(file, fileData);
		fileClose(file);		
	
	end

end