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
				if ($message eq '43E') {
					$refresh = 1;
					if (1 eq ($d5 & 32)>>5)
						{
							$doorFrontLeft = "Opened";
						}
					else
						{
							$doorFrontLeft = "Closed";
						}
					if (1 eq ($d5 & 16)>>4)
						{
							$doorFrontRight = "Opened";
						}
					else
						{
							$doorFrontRight = "Closed";
						}
				}	
				if ($message eq '217') {
					$refresh = 1;
					$speed1=$d5;
					$speed2=$d6;
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
			print "\n";
			print "FRONT LEFT :\t $doorFrontLeft\n";
			print "FRONT RIGHT:\t $doorFrontRight\n";
			print "BACK  LEFT :\t $doorBackLeft\n";
			print "BACK  RIGHT:\t $doorBackRight\n";
			$speed=($speed1*256+$speed2)/100;
			print "SPEED:\t $speed\n";
			$refresh = 0;
		}



    }
    close(FILE);
}


