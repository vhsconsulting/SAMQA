-- liquibase formatted sql
-- changeset SAMQA:1754374164151 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\vendor_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/vendor_external.sql:null:e17edbf28b8050189c7ea7be882190ccc6e19083:create

create table samqa.vendor_external (
    vendor_id   varchar2(255 byte),
    vendor_name varchar2(2000 byte),
    address1    varchar2(2000 byte),
    address2    varchar2(2000 byte),
    city        varchar2(255 byte),
    state       varchar2(255 byte),
    zip         varchar2(255 byte),
    phone       varchar2(255 byte),
    tax_id      varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory claim_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( claim_dir : 'vendors.csv' )
) reject limit unlimited;

