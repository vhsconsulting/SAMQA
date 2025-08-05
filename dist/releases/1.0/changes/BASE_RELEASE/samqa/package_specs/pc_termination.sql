-- liquibase formatted sql
-- changeset SAMQA:1754374140795 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_termination.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_termination.sql:null:3161b7a7ed8aafcd55f81503c4c3770e5ae053d9:create

create or replace package samqa.pc_termination as
    procedure export_termination_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
    );

    procedure terminate_dependants (
        p_batch_number in varchar2
    );

    procedure terminate_plans (
        p_batch_number in varchar2,
        p_user_id      in number
    );

    procedure import_termination_file (
        p_batch_number in varchar2
    );

    procedure insert_termination_interface (
        p_acc_id          in number,
        p_entrp_id        in number,
        p_life_event_code in varchar2,
        p_effective_date  in date,
        p_user_id         in number,
        p_plan_type       in varchar2,
        p_ben_plan_id     in number,
        p_batch_number    in number default null
    );

      -- 4/23/2011 changes
    procedure ins_termination_interface (
        p_acc_id          in number,
        p_entrp_id        in number,
        p_life_event_code in varchar2,
        p_effective_date  in date,
        p_user_id         in number,
        p_plan_type       in varchar2,
        p_ben_plan_id     in number,
        p_batch_number    in varchar2
    );

    procedure term_all_plans (
        p_acc_id          in number,
        p_batch_number    in varchar2,
        p_life_event_code in varchar2,
        p_effective_date  in date,
        p_user_id         in number
    );

    procedure term_one_plan (
        p_acc_id          in number,
        p_batch_number    in varchar2,
        p_ben_plan_id     in number,
        p_entrp_id        in number,
        p_life_event_code in varchar2,
        p_effective_date  in date,
        p_user_id         in number
    );

    procedure process_termination_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
    );

end pc_termination;
/

