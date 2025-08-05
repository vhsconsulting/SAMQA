-- liquibase formatted sql
-- changeset SAMQA:1754374155811 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eb_trans_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eb_trans_codes.sql:null:a826ba6066c053649c47158a0244ddd921ccd76d:create

create table samqa.eb_trans_codes (
    trans_code  varchar2(9 byte) not null enable,
    description varchar2(80 byte) not null enable,
    trans_sign  number(1, 0) not null enable,
    explanation varchar2(500 byte)
);

