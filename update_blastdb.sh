#!/bin/bash

function ftp_download {

    if [ $# != 1 ]; then
        echo -e "Usage: $0 [database_name]"
        exit 1
    fi

    # setting
    prefix=ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA
    db_name=$prefix/${1}.gz
    db_md5=${db_name}.md5

    if [[ -e ${1}.gz ]]; then
        read -p "${1}.gz exists, overwrite it?" -n 1 -r
        echo 
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then 
            echo "[ftp_download] $db_name was not downloaded, please backup your local version, then try again!"
            exit 0
        fi
    fi

    # download
    rm -f ${1}.gz ${1}.gz.md5
    wget $db_name
    wget $db_md5

    # check md5sum
    md5sum --status -c ${1}.gz.md5 && echo -e "[ftp_download] $1 was completely downloaded!" 

}

function log_update {

    if [[ ! -e readme.txt ]]; then
        touch readme.txt
    fi

    if [ $# != 1 ]; then
        echo -e "Usage: $0 [database_name]"
        exit 1
    fi

    now="$(date +'%d/%m/%Y')"
    printf "$1 database was updated on %s (dd/mm/yy) \n" "$now" >> readme.txt   

}

function mkblastdb {

    if [ $# != 2 ]; then
        echo -e "Usage: $0 [database_file(.gz)] [dbtype]"
        exit 1
    fi

    db_name=$1
    dbtype=$2

    # uncompress if necessary
    if [[ $db_name == *.gz ]]; then 
        echo -e "[mkblastdb] uncompress $db_name ..."
        gzip -d $db_name
        db_name=${db_name%.gz}
        echo -e "[mkblastdb] Done!"
    fi

    # makeblastdb
    echo -e "[mkblastdb] makeblastdb ..."
    makeblastdb -in $db_name -input_type fasta -dbtype $dbtype -out $db_name -parse_seqids
    echo -e "[mkblastdb] Done!"
}


# -------------------
# update nt database
# ------------------
ftp_download nt
mkblastdb nt.gz nucl
log_update nt

# ------------------
# update nr database
# ------------------
ftp_download nr
mkblastdb nr prot
log_update nr

# diamond makedb
ln -s nr nr.faa
diamond makedb --in nr.faa -d nr

# ----------------
# update swissprot
# ----------------
ftp_download swissprot
mkblastdb swissprot.gz prot
log_update swissprot
