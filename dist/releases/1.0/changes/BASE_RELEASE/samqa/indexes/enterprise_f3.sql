-- liquibase formatted sql
-- changeset SAMQA:1754373931335 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enterprise_f3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enterprise_f3.sql:null:faff49741bf205bb82fecbb586b6ba7ad349f60e:create

create index samqa.enterprise_f3 on
    samqa.enterprise ( upper(name) );

