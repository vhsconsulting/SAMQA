-- liquibase formatted sql
-- changeset SAMQA:1754373933642 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\website_logs_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/website_logs_n3.sql:null:44a7f51dc403134a6e827eceefa2322b868b8da9:create

create index samqa.website_logs_n3 on
    samqa.website_logs (
        message
    );

