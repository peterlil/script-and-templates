REM Make sure you are in the folder where you unzipped diskspd. 
REM -t: Make sure this value is set to the number of logical cores on the VM.
.\amd64\diskspd.exe -b64K -d30 -h -L -o1 -t32 -w0 -r -c10240M M:\io.dat >  .\Diskpdresult_read_64k_M_o1.txt
.\amd64\diskspd.exe -b64K -d30 -h -L -o2 -t32 -w0 -r -c10240M M:\io.dat >  .\Diskpdresult_read_64k_M_o2.txt
.\amd64\diskspd.exe -b64K -d30 -h -L -o4 -t32 -w0 -r -c10240M M:\io.dat >  .\Diskpdresult_read_64k_M_o4.txt
.\amd64\diskspd.exe -b64K -d30 -h -L -o8 -t32 -w0 -r -c10240M M:\io.dat >  .\Diskpdresult_read_64k_M_o8.txt
.\amd64\diskspd.exe -b64K -d30 -h -L -o16 -t32 -w0 -r -c10240M M:\io.dat > .\Diskpdresult_read_64k_M_o16.txt
.\amd64\diskspd.exe -b64K -d30 -h -L -o32 -t32 -w0 -r -c10240M M:\io.dat > .\Diskpdresult_read_64k_M_o32.txt
