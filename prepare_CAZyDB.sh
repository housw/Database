
# download form http://csbl.bmb.uga.edu/dbCAN/download.php
wget http://csbl.bmb.uga.edu/dbCAN/download/CAZyDB.07152016.fa

# makeblastdb
makeblastdb -in CAZyDB.07152016.fa -input_type fasta -dbtype 'prot' -out CAZyDB 
