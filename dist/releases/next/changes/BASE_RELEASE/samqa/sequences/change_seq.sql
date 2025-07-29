-- liquibase formatted sql
-- changeset SAMQA:1753779760905 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\change_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/change_seq.sql:null:92005372b6da18867869c1a6a48c5ff2eaf86539:create

create sequence samqa.change_seq minvalue 1 maxvalue 1000000000000000000000000000 increment by 1 start with 45829022 nocache noorder nocycle
nokeep noscale global;

