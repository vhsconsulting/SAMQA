-- liquibase formatted sql
-- changeset SAMQA:1754374151804 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\as_sftp_known_hosts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/as_sftp_known_hosts.sql:null:7c63a60ff69883c0331acc5bb5901618cdd4b9d0:create

create table samqa.as_sftp_known_hosts (
    host        varchar2(1000 char),
    fingerprint varchar2(100 char)
);

