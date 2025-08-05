-- liquibase formatted sql
-- changeset SAMQA:1754374137659 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_external_scheduler.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_external_scheduler.sql:null:47c0469bb5250a76122bba126cae6b33f64011bd:create

create or replace package samqa.pc_external_scheduler as
    procedure ext_scheduler (
        p_job_name      in varchar2,
        p_script        in varchar2,
        p_argument      in varchar2,
        x_error_message out varchar2
    );

    procedure hra_bps_process (
        p_action         in varchar2,
        x_error_message  out varchar2,
        x_file_name      out varchar2,
        x_submitted_time out varchar2
    );

    function check_result (
        p_action in varchar2
    ) return varchar2;

end pc_external_scheduler;
/

