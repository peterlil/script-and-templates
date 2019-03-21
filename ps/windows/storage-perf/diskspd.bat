REM Make sure you are in the folder where you unzipped diskspd. 
REM -t: Make sure this value is set to the number of logical cores on the VM.
SET diskspd_path=%HOMEDRIVE%%HOMEPATH%\Downloads\DiskSpd-2.0.21a
SET mydocs=%HOMEDRIVE%%HOMEPATH%\Documents
SET test_path=M:\io.dat
SET logical_processors=32
REM %diskspd_path%\amd64\diskspd.exe -b64K -d360 -h -L -o32 -t32 -w0 -r -c10240M M:\io.dat > %mydocs%\1.txt

REM Writes
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o1  -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o1.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o2  -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o2.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o4  -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o4.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o8  -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o8.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o16 -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o16.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o32 -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o32.txt

REM Reads
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o1  -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o1.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o2  -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o2.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o4  -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o4.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o8  -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o8.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o16 -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o16.txt
%diskspd_path%\amd64\diskspd.exe -b64K -d30 -h -L -o32 -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o32.txt

REM Writes
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o1  -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o1.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o2  -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o2.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o4  -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o4.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o8  -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o8.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o16 -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o16.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o32 -t%logical_processors% -w100 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o32.txt

REM Reads
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o1  -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o1.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o2  -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o2.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o4  -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o4.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o8  -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o8.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o16 -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o16.txt
%diskspd_path%\amd64\diskspd.exe -b8K -d30 -h -L -o32 -t%logical_processors% -w0 -r -c10240M %test_path% > %mydocs%\Diskpdresult_read_64k_M_o32.txt

