-- liquibase formatted sql
-- changeset SAMQA:1754374135840 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_employer_divisions.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_employer_divisions.sql:null:4d16b2e1034a118feae73e37eb7bb4dbe111f81b:create

create or replace package samqa.pc_employer_divisions as
    procedure insert_employer_divisions (
        p_division_code in varchar2,
        p_division_name in varchar2,
        p_description   in varchar2,
        p_entrp_id      in number,
        p_division_main in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure insert_employer_division (
        p_division_code in varchar2,
        p_division_name in varchar2,
        p_description   in varchar2,
        p_address1      in varchar2,
        p_address2      in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zip           in varchar2,
        p_phone         in varchar2,
        p_fax           in varchar2,
        p_vendor_ref    in varchar2,
        p_vendor        in varchar2,
        p_entrp_id      in number,
        p_user_id       in number,
        x_division_id   out number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure update_employer_divisions (
        p_division_id   in number,
        p_division_code in varchar2,
        p_division_name in varchar2,
        p_description   in varchar2,
        p_entrp_id      in number,
        p_division_main in number,
        p_status        in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure delete_employer_divisions (
        p_division_id in number,
        p_user_id     in number
    );

    procedure reassign_division (
        p_division_code in varchar2,
        p_acc_id        in number,
        p_entrp_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function get_division_count (
        p_entrp_id      in number,
        p_division_code in varchar2
    ) return number;

    function get_employee_count (
        p_entrp_id      in number,
        p_division_code in varchar2
    ) return number;

    function get_division_code (
        p_pers_id  in number,
        p_entrp_id in number
    ) return varchar2;

    function get_division_id_for_cobra (
        p_cobra_number in number
    ) return number;

    function get_division_name (
        p_division_code in varchar2,
        p_entrp_id      in number
    ) return varchar2;

end pc_employer_divisions;
/

