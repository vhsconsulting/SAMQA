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


-- sqlcl_snapshot {"hash":"e13e5c641dbc1efcfa24bdf181bf126abdfca7d5","type":"PACKAGE_SPEC","name":"TEST_PKG","schemaName":"SAMQA","sxml":""}