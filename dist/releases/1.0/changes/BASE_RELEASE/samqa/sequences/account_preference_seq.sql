-- liquibase formatted sql
-- changeset SAMQA:1754374147377 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\account_preference_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/account_preference_seq.sql:null:16ad41ead75ec82d573caf9334205ba34e752808:create

create sequence samqa.account_preference_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 176020 cache 20
noorder nocycle nokeep noscale global;

