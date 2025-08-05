-- liquibase formatted sql
-- changeset SAMQA:1754373937832 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ga_lic_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ga_lic_seq.sql:null:599fc34666247130c61dfb96612b9f7c9ae1ae0e:create

grant select on samqa.ga_lic_seq to rl_sam_rw;

