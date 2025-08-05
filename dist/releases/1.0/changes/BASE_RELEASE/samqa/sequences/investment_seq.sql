-- liquibase formatted sql
-- changeset SAMQA:1754374149038 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\investment_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/investment_seq.sql:null:6bb5ccbd099f624056687ec029b99d2337537f66:create

create sequence samqa.investment_seq minvalue 1 maxvalue 9999999999 increment by 1 start with 3673 nocache noorder nocycle nokeep noscale
global;

