-- liquibase formatted sql
-- changeset SAMQA:1754374153210 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_edi_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_edi_external.sql:null:9f582dead819a5d9dd995a5d2947a6d01b26ca8f:create

create table samqa.claim_edi_external (
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
        fields terminated by '*' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( edi_dir : '837P_20101022_Aug25-31.txt' )
) reject limit unlimited;

