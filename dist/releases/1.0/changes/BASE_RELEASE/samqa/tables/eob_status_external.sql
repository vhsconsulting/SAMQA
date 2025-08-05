-- liquibase formatted sql
-- changeset SAMQA:1754374157747 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eob_status_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eob_status_external.sql:null:588bcdfcad43c39bad659e5248c2b80ea36af668:create

create table samqa.eob_status_external (
    user_id         varchar2(100 byte),
    account_id      varchar2(100 byte),
    action          varchar2(100 byte),
    carrier_name    varchar2(3200 byte),
    carrier_id      varchar2(100 byte),
    user_name       varchar2(100 byte),
    password        varchar2(100 byte),
    status_id       varchar2(100 byte),
    status_message  varchar2(3200 byte),
    member_id       varchar2(100 byte),
    created_on      varchar2(100 byte),
    last_updated_on varchar2(100 byte)
)
organization external ( type oracle_loader
    default directory hex_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' missing field values are null
    ) location ( hex_ins_dir : 'HEx_ins_24232_3188840472.csv' )
) reject limit unlimited;

