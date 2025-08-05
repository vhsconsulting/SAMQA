-- liquibase formatted sql
-- changeset SAMQA:1754374134157 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_ben_life_events.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_ben_life_events.sql:null:c546371e67b8c24e9f56ba2d7586cc5902f31a22:create

create or replace package samqa.pc_ben_life_events as
    type varchar2_tbl is
        table of varchar2(3200) index by binary_integer;
    function array_fill (
        p_array       varchar2_tbl,
        p_array_count number
    ) return varchar2_tbl;

    type life_events_row_t is record (
            life_event_date date,
            life_event      varchar2(200),
            annual_balance  number
    );
    type ann_elec_change_row_t is record (
            acc_num                 varchar2(200),
            acc_id                  number,
            plan_id                 number,
            plan_type               varchar2(200),
            life_event_code         varchar2(200),
            event_desc              varchar2(200),
            description             varchar2(4000),
            effective_date          varchar2(30),
            annual_election         number,
            status                  varchar2(30),
            status_code             varchar2(30),
            entrp_id                number,
            pers_name               varchar2(200),
            plan_start_date         varchar2(30),
            plan_end_date           varchar2(30),
            current_annual_election number,
            cov_tier_name           varchar2(255),
            product_type            varchar2(30),
            batch_number            number,
            status_code_desc        varchar2(255)
    );
    type ann_elec_change_t is
        table of ann_elec_change_row_t;
    type life_events_table_t is
        table of life_events_row_t;
    procedure insert_ben_life_events (
        p_acc_id          in number,
        p_ben_plan_id     in number,
        p_plan_type       in varchar2,
        p_life_event_code in varchar2,
        p_description     in varchar2,
        p_annual_election in number,
        p_payroll_contrib in number,
        p_effective_date  in varchar2,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure process_ben_life_events (
        p_batch_number    in number,
        p_life_event_code in varchar2,
        p_user_id         in number
    );

    procedure change_annual_election (
        p_ee_acc_id       in number,
        p_entrp_id        in number,
        p_plan_type       in varchar2,
        p_amount          in number,
        p_batch_number    in number,
        p_effective_date  in date,
        p_user_id         in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_reason          in varchar2
    );

    function get_life_events (
        p_acc_id     in number,
        p_plan_type  in varchar2,
        p_start_date in varchar2,
        p_end_date   in varchar2
    ) return life_events_table_t
        pipelined
        deterministic;

    function get_ann_elec_changes (
        p_acc_id      in number,
        p_ben_plan_id in number default null
    ) return ann_elec_change_t
        pipelined
        deterministic;

    function get_er_ann_elec_changes (
        p_entrp_id in number
    ) return ann_elec_change_t
        pipelined
        deterministic;

    function get_approved_ann_elec_changes (
        p_entrp_id     in number,
        p_batch_number in number
    ) return ann_elec_change_t
        pipelined
        deterministic;

    procedure insert_ee_ben_life_events (
        p_acc_id          in number,
        p_ben_plan_id     in number,
        p_plan_type       in varchar2,
        p_life_event_code in varchar2,
        p_description     in varchar2,
        p_annual_election in number,
        p_payroll_contrib in number,
        p_effective_date  in varchar2,
        p_cov_tier_name   in varchar2,
        p_user_id         in number,
        p_batch_number    in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure approve_ee_ben_life_events (
        p_acc_id          in varchar2_tbl,
        p_ben_plan_id     in varchar2_tbl,
        p_annual_election in varchar2_tbl,
        p_payroll_contrib in varchar2_tbl,
        p_effective_date  in varchar2_tbl,
        p_batch_number    in varchar2_tbl,
        p_status          in varchar2_tbl,
        p_description     in varchar2_tbl,
        p_cov_tier_name   in varchar2_tbl,
        p_process_batch   in number,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

end;
/

