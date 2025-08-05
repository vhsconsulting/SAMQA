-- liquibase formatted sql
-- changeset SAMQA:1754373938771 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.as_sftp_known_hosts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.as_sftp_known_hosts.sql:null:ed916be7edb33ced5892794a27a57727ec305020:create

grant delete on samqa.as_sftp_known_hosts to rl_sam_rw;

grant insert on samqa.as_sftp_known_hosts to rl_sam_rw;

grant select on samqa.as_sftp_known_hosts to rl_sam1_ro;

grant select on samqa.as_sftp_known_hosts to rl_sam_ro;

grant select on samqa.as_sftp_known_hosts to rl_sam_rw;

grant update on samqa.as_sftp_known_hosts to rl_sam_rw;

