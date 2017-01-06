#! perl -w 
use DBI;
no warnings;

$dbh = DBI->connect("DBI:mysql:can", 'root','toor') or die "Error connecting to database";

system("MODE COM4:115200,N,8,1,P");

# Загружаем данные из DB
	if ($DEBUG > 0) {print "--------------------------------------------\n";}
	if ($DEBUG > 0) {print "\nLoading... ";}
	
	$query = "select message, byte, bit, value from messages";
	$sth = $dbh->prepare($query);
	$count=$sth -> execute;
          
	  while (@dbdata = $sth->fetchrow_array()) {
		my $message = $dbdata[0];
		my $byte = $dbdata[1];
		my $bit = $dbdata[2];
		my $value = $dbdata[3];
		if ($value eq undef) 
			{$data{$message}{$byte}{$bit}=' '} 
		else
			{$data{$message}{$byte}{$bit}=$value;}
#		print "$message $byte $bit = $value\n"
	  }
		if ($DEBUG > 0) {print " [DONE];\n";}
	  if ($sth->rows == 0) {
		if ($DEBUG > 0) {print " [NO DATA];\n";}
	  }
	  $sth->finish;	
		if ($DEBUG > 0) {print "--------------------------------------------\n";}
# данные из DB загружены

while (1) {
    open( FILE, "+>COM4" ) or die("Error reading file, stopped");
    my ($buffer) = "";
	my ($line) = "";
	my ($i) = 0;
	
    while ( read( FILE, $buffer, 1 ) ) {

		if ($buffer eq "\n"){			
			#print "\t$line\n";							
			$line =~ m/S: (\w{3})       DLC: (\d)  Data: (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2})/s;
			
			$message=$1;
			
			if ($message ne ""){
				$size=$2;
				
				#сохраняем данные в массив
				$d[1]=hex($3);
				$d[2]=hex($4);
				$d[3]=hex($5);
				$d[4]=hex($6);
				$d[5]=hex($7);
				$d[6]=hex($8);
				$d[7]=hex($9);
				$d[8]=hex($10);			
				
				$lineToPrint='';
				$printNeeded=0;
				
				
				$lineToPrint= $lineToPrint."$message ";
				for (my $byte=1;$byte<=8;$byte++){
					$lineToPrint= $lineToPrint." | ";				
					#for (my $bit=0;$bit<8;$bit){
					for (my $bit=8;$bit>0;$bit--){
					
						# два разных алгоритма для получния очередного бита
						#$value = ($d[$byte] & (2**($bit-1)))>>$bit;
						$value = ($d[$byte]>>($bit-1))&1;					
						
						#if ($message eq '43E' and $byte==5 and $bit==6)
						#	{#print "$query | $selected_value | $value \n";
						#	}
						
						# такой пакет еще не получали или мы получили значение бита, которое не равно обычному значению . надо его отобразить
						if ((($data{$message}{$byte}{$bit} ne $value)and($data{$message}{$byte}{$bit} ne ' ')) or ($data{$message}{$byte}{$bit} eq undef)){							
								# or ((($data{$message}{$byte}{$bit} ne $value)and($data{$message}{$byte}{$bit} ne undef) ))
								$lineToPrint= $lineToPrint."$value";					
								$printNeeded=1;
						}												
							else					
						{
							$lineToPrint= $lineToPrint."_";
						}			
						
					}
				}
			}
			if ($printNeeded == 1){
				print "+ $lineToPrint\n";
			}	
			$line="";
		}
				else
		{
			$line=$line.$buffer;
		}
	}
}