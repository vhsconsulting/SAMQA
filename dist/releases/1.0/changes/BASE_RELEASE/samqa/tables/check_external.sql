-- liquibase formatted sql
-- changeset SAMQA:1754374152935 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\check_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/check_external.sql:null:dce2226e0b3143bcfab52693b2ece1e1cc9a669f:create

create table samqa.check_external (
    file_name    varchar2(250 byte),
    check_number varchar2(15 byte),
    acc_num      varchar2(20 byte),
    check_dt     varchar2(15 byte),
    mailed_dt    varchar2(15 byte)
)
organization external ( type oracle_loader
    default directory checks_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( checks_dir : 'STERLING_RECEIPT_0220240221001_manual' )
) reject limit unlimited;

