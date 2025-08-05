-- liquibase formatted sql
-- changeset SAMQA:1754374142426 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\test_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/test_pkg.sql:null:e13e5c641dbc1efcfa24bdf181bf126abdfca7d5:create

create or replace package samqa.test_pkg as
    type employee_rec is record (
            employee_id     varchar2(40),
            employee_number varchar2(50),
            job             varchar2(240),
            salary          number
    );
    type employee_t is
        table of employee_rec;
    function get_employee_details (
        p_employee_id in number
    ) return employee_t
        pipelined
        deterministic;

end test_pkg;
/

