-- liquibase formatted sql
-- changeset SAMQA:1754374147802 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\change_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/change_id_seq.sql:null:7b0fac547db8a77de9a3581eaa5324f0f3587df0:create

create sequence samqa.change_id_seq minvalue 1 maxvalue 1000000000000000000000000000 increment by 1 start with 66618 nocache noorder nocycle
nokeep noscale global;

