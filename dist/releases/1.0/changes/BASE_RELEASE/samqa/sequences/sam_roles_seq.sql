-- liquibase formatted sql
-- changeset SAMQA:1754374149997 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\sam_roles_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/sam_roles_seq.sql:null:6668f32c854bbda7e7c613cb711205561ea88169:create

create sequence samqa.sam_roles_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder nocycle
nokeep noscale global;

