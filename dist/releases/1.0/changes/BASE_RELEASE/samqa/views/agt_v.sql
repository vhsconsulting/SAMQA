-- liquibase formatted sql
-- changeset SAMQA:1754374168003 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\agt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/agt_v.sql:null:96d37136195e44436dce894fd1345fdc50cc0870:create

create or replace force editionable view samqa.agt_v (
    low,
    age,
    male,
    female,
    na,
    total
) as
    (
        select
            nvl(low, -1) as low,
            age,
            male,
            female,
            na,
            total
        from
            agc_v
        union all
        select
            999,
            'Total',
            sum(male),
            sum(female),
            sum(na),
            sum(total)
        from
            agc_v
    );

