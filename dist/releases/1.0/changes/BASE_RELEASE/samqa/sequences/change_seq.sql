-- liquibase formatted sql
-- changeset SAMQA:1754374147816 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\change_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/change_seq.sql:null:c48c355a29ce07a5b181cb9e485b2505be23b852:create

create sequence samqa.change_seq minvalue 1 maxvalue 1000000000000000000000000000 increment by 1 start with 45829026 nocache noorder nocycle
nokeep noscale global;

