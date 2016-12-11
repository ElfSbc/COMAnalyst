#! perl -w
use DBI;
no warnings;

$dbh = DBI->connect("DBI:mysql:can", 'root','toor') or die "Error connecting to database";

$DEBUG = 1;

system("MODE COM3:115200,N,8,1,P");

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
    open( FILE, "+>COM3" ) or die("Error reading file, stopped");
    my ($buffer) = "";
	my ($line) = "";
	my ($i) = 0;
	
    while ( read( FILE, $buffer, 1 ) ) { #читаем 1 байт
		if ($buffer eq "\n"){				# если это перенос строки, то надо обработать эту строку
			$line =~ m/S: (\w{3})       DLC: (\d)  Data: (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2}) (\w{2})/s;
			
			$message=$1;
			
			if  ($message ne "" and $message ne undef){ # если сообщения нет. То и обработывать не надо
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
										
				
				# цикл по всем битам пакета
				for (my $byte=1;$byte<=8;$byte++){
					for (my $bit=1;$bit<=8;$bit++){
							
							$value = ($d[$byte]>>($bit-1))&1;
														
							# undef - если даннные не найдены, то этот пакет мы еще не получали
							# null/'' - значит этот бит изменяется
							# 0 - значит, что этот бит всегда был = 0
							# 1 - значит, что этот бит всегда был = 1
							
							if ($DEBUG > 1) {print " $message $byte $bit =  '$value' \t-->\t '$data{$message}{$byte}{$bit}';\n"; }
							
							# если данных о пакете этого типа нет в базе, то надо его сохранить
							if ($data{$message}{$byte}{$bit} eq undef){
								if ($DEBUG > 0) {print "NEW \t$message\t$byte:$bit=$value\n";}
								
								$query = "insert into messages (message, byte, bit, value) values ('$message',$byte,$bit,$value)";
								$sth1 = $dbh->prepare($query);
								$sth1 -> execute;
								$sth1 -> finish;			
								
								$data{$message}{$byte}{$bit} = $value;
							}						
							if (($data{$message}{$byte}{$bit} ne $value) and ($data{$message}{$byte}{$bit} ne undef)and ($data{$message}{$byte}{$bit} ne ' ')){
								# если в базе сохранено другое значение этого бита, то этот бит изменяется периодически и нужно сохранить Null
								if ($DEBUG > 0){print "CHANGED \t$message\t$byte:$bit=$value\n";}
								$query = "update messages SET value = NULL WHERE message='$message' and byte=$byte and bit=$bit";
								$sth1 = $dbh->prepare($query);
								$sth1 -> execute;
								$sth1 -> finish;
								
								$data{$message}{$byte}{$bit} = ' ';
							}							
					}
				}
				
			}
			# т.к. мы эту строку обработали, то надо ее очистить для примема новой
			$line="";
		}
		else
		{
			# если это не перенос строки, то надо сохрать этот символ
			$line=$line.$buffer;
		}
    }
    close(FILE);
}


