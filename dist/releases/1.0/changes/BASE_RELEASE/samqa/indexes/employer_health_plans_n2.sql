-- liquibase formatted sql
-- changeset SAMQA:1754373931014 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_health_plans_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_health_plans_n2.sql:null:78fbda46cf0d93063df59e541d018cd36b26732c:create

create index samqa.employer_health_plans_n2 on
    samqa.employer_health_plans (
        entrp_id,
        carrier_id
    );

