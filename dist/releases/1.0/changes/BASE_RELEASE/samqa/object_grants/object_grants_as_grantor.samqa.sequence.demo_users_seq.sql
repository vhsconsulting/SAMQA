-- liquibase formatted sql
-- changeset SAMQA:1754373937627 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.demo_users_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.demo_users_seq.sql:null:808ae9c351abb0b5d13dee9ffbb5135f71e530dd:create

grant select on samqa.demo_users_seq to rl_sam_rw;

