#! perl -w
use DBI;
no warnings;

$messageId='000';
my ($messageId) = @ARGV;


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
				#print "$message\n";
				if ($message eq $messageId or $messageId eq "") {
					printf ("| %8b | %8b | %8b | %8b | %8b | %8b | %8b | %8b |",$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8);
					print "\t$message\t $size\t $d1 $d2 $d3 $d4 $d5 $d6 $d7 $d8\n";							
				}	
			}				
			$line="";
		}
		else
		{
			$line=$line.$buffer;
		}
    }
    close(FILE);
}