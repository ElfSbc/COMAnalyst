#! perl -w
use DBI;
no warnings;


system("MODE COM3:115200,N,8,1,P");

while (1) {
    open( FILE, "+>COM3" ) or die("Error reading file, stopped");
    my ($buffer) = "";
	my ($line) = "";
	my ($i) = 0;
	
    while ( read( FILE, $buffer, 1 ) ) {

		if ($buffer eq "\n"){			
			#print "\t$line\n";							
			$line =~ m/S: (\w{3})       DLC: (\d)  Data: (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2})/s;
			$message=$1;
			$size=$2;
			$d1=hex($3);
			$d2=hex($4);
			$d3=hex($5);
			$d4=hex($6);
			$d5=hex($7);
			$d6=hex($8);
			$d7=hex($9);
			$d8=hex($10);					
			
			if ($message ne ""){
				if ($message eq '110') {
					$refresh = 1;
					if (0 eq ($d7 & (1))>>0)
						{
							$doorFrontLeft = "Opened";
						}
					else
						{
							$doorFrontLeft = "Closed";
						}
					if (0 eq ($d7 & (2))>>1)
						{
							$doorFrontRight = "Opened";
						}
					else
						{
							$doorFrontRight = "Closed";
						}
					if (0 eq ($d7 & (4))>>2)
						{
							$doorBackRight = "Opened";
						}
					else
						{
							$doorBackRight = "Closed";
						}

					if (0 eq ($d7 & 8)>>3)
						{
							$doorBackLeft = "Opened";
						}
					else
						{
							$doorBackLeft = "Closed";
						}
					if (0 eq ($d7 & 16)>>4)
						{
							$doorBack = "Opened";
						}
					else
						{
							$doorBack = "Closed";
						}
					if (0 eq ($d7 & 32)>>5)
						{
							$doorFront = "Opened";
						}
					else
						{
							$doorFront = "Closed";
						}



				}	
			}				
			$line="";
		}
		else
		{
			$line=$line.$buffer;
		}
		
		if ($refresh==1)
		{
			print "\n\n\n\n\n\n\n\n";
			print "FRONT LEFT :\t $doorFrontLeft\n";
			print "FRONT RIGHT:\t $doorFrontRight\n";
			print "BACK  LEFT :\t $doorBackLeft\n";
			print "BACK  RIGHT:\t $doorBackRight\n";
			print "BACK       :\t $doorBack\n";
			print "FRONT      :\t $doorFront\n";
			$refresh = 0;
		}



    }
    close(FILE);
}


