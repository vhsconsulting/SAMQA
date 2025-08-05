-- liquibase formatted sql
-- changeset SAMQA:1754374156814 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\enrollment_edi_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/enrollment_edi_external.sql:null:04c96a9277f3b10570beaadd9e70ffcb5b023f4e:create

create table samqa.enrollment_edi_external (
    seg varchar2(3 byte),
    s01 varchar2(80 byte),
    s02 varchar2(80 byte),
    s03 varchar2(80 byte),
    s04 varchar2(80 byte),
    s05 varchar2(80 byte),
    s06 varchar2(80 byte),
    s07 varchar2(80 byte),
    s08 varchar2(80 byte),
    s09 varchar2(80 byte),
    s10 varchar2(80 byte),
    s11 varchar2(80 byte),
    s12 varchar2(80 byte),
    s13 varchar2(80 byte),
    s14 varchar2(80 byte),
    s15 varchar2(80 byte),
    s16 varchar2(80 byte),
    s17 varchar2(80 byte),
    s18 varchar2(80 byte)
)
organization external ( type oracle_loader
    default directory edi_dir access parameters (
        records delimited by'~'
            badfile mailer_dir : '834_edi_enrollment.bad'
            logfile edi_dir : '834_edi_enrollment.log'
            skip 1
        fields terminated by '*' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( edi_dir : '834_20150105_CRMC.txt' )
) reject limit unlimited;

