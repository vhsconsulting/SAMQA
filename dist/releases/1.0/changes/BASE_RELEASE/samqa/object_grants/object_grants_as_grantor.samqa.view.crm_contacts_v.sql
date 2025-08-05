-- liquibase formatted sql
-- changeset SAMQA:1754373943450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.crm_contacts_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.crm_contacts_v.sql:null:f83963c4bdd737678112123b62f00eca3d0c3367:create

grant select on samqa.crm_contacts_v to rl_sam1_ro;

grant select on samqa.crm_contacts_v to rl_sam_rw;

grant select on samqa.crm_contacts_v to rl_sam_ro;

grant select on samqa.crm_contacts_v to sgali;

