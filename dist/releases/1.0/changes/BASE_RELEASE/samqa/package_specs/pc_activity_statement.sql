-- liquibase formatted sql
-- changeset SAMQA:1754374134075 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_activity_statement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_activity_statement.sql:null:4091d7692e963b9086f0243777b288199de53877:create

create or replace package samqa.pc_activity_statement as
    type er_statement_rec is record (
            entrp_id       number,
            er_acc_num     varchar2(30),
            acc_num        varchar2(30),
            first_name     varchar2(255),
            middle_name    varchar2(30),
            last_name      varchar2(255),
            fee_date       date,
            division_code  varchar2(255),
            emp_deposit    number,
            subscr_deposit number,
            er_fee_deposit number,
            total          number
    );
    type er_statement_tbl is
        table of er_statement_rec;
    procedure process_yearly_activity (
        p_acc_id_from in number,
        p_acc_id_to   in number
    );

    procedure generate_activity_statement (
        p_statement_method in varchar2,
        p_start_date       in date default sysdate,
        p_end_date         in date default sysdate,
        p_acc_num          in varchar2 default null,
        p_entrp_id         in number default null,
        x_batch_number     in out number
    );

    function get_er_statement_detail (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) return er_statement_tbl
        pipelined
        deterministic;

    function get_er_statement (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) return er_statement_tbl
        pipelined
        deterministic;

 -- Below added by Swamy for Ticket#8984
    type rec_emp_contrib_detail is record (
            entrp_id       number(9),
            group_acc_num  varchar2(20),
            name           varchar2(329),
            first_name     varchar2(255),
            middle_name    varchar2(1),
            last_name      varchar2(50),
            acc_num        varchar2(20),
            fee_date       date,
            emp_deposit    number,
            subscr_deposit number,
            ee_fee_deposit number,
            er_fee_deposit number,
            total          number
    );
    type tbl_emp_contrib_detail is
        table of rec_emp_contrib_detail;

 -- Below Function added by Swamy for Ticket#8984(Related to SQL Injection)
    function get_emp_contrib_detail (
        p_group_acc_num in varchar2,
        p_entrp_id      in varchar2,
        p_start_date    in varchar2,
        p_end_date      in varchar2,
        p_sort          in varchar2
    ) return tbl_emp_contrib_detail
        pipelined;

end pc_activity_statement;
/

