create or replace package samqa.pc_user_security_pkg is
    type user_sec_info_row_t is record (
            site_key               varchar2(2000),
            site_image             number,
            pw_question1           number,
            pw_question1_desc      varchar2(255),
            pw_answer1             varchar2(255),
            pw_question2           number,
            pw_question2_desc      varchar2(255),
            pw_answer2             varchar2(255),
            pw_question3           number,
            pw_question3_desc      varchar2(255),
            pw_answer3             varchar2(255),
            security_setting_exist varchar2(1)
    );
    type user_sec_info_t is
        table of user_sec_info_row_t;
    type user_rand_sec_info_row_t is record (
            pw_question      number,
            pw_question_desc varchar2(255),
            pw_answer        varchar2(255)
    );
    type user_rand_sec_info_t is
        table of user_rand_sec_info_row_t;
    procedure validate_user_security_info (
        p_user_id       in number,
        p_site_key      in varchar2,
        p_pw_question1  in number,
        p_pw_answer1    in varchar2,
        p_pw_question2  in number,
        p_pw_answer2    in varchar2,
        p_pw_question3  in number,
        p_pw_answer3    in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure insert_user_security_info (
        p_user_id       in number,
        p_site_key      in varchar2,
        p_pw_question1  in number,
        p_pw_answer1    in varchar2,
        p_pw_question2  in number,
        p_pw_answer2    in varchar2,
        p_pw_question3  in number,
        p_pw_answer3    in varchar2,
        p_remember_pc   in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure insert_user_security_info (
        p_user_id               in number,
        p_otp_verified          in varchar2,
        p_verified_phone_type   in varchar2,
        p_verified_phone_number in varchar2
    );

    function security_setting_exist (
        p_user_id in number
    ) return varchar2;

    procedure change_site_image (
        p_user_id       in number,
        p_site_image    in number,
        p_site_key      in varchar2,
        p_remember_pc   in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure change_security_question (
        p_user_id       in number,
        p_q1            in number,
        p_ans1          in varchar2,
        p_q2            in number,
        p_ans2          in varchar2,
        p_q3            in number,
        p_ans3          in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function security_setting_complete (
        p_user_id in number
    ) return varchar2;

    function get_image (
        p_user_id in number
    ) return blob;

    function get_security_question (
        p_question_id in number
    ) return varchar2;

    function get_security_info (
        p_user_id in number
    ) return user_sec_info_t
        pipelined
        deterministic;

    function get_rand_sec_info (
        p_user_id in number
    ) return user_rand_sec_info_t
        pipelined
        deterministic;
-- OTP changes
    procedure update_otp_verified (
        p_user_id  in number,
        p_verified in varchar2 default 'N'
    );

    procedure update_otp_phone (
        p_user_id      in number,
        p_device_type  in varchar2,
        p_phone_number in varchar2,
        p_verified     in varchar2 default 'N'
    );

    function get_otp_verified (
        p_user_id in number
    ) return varchar2;

    function show_phone_update_modal (
        p_user_id in number
    ) return varchar2;
-- update email and phone from modal window
    procedure update_otp_phone (
        p_user_id      in number,
        p_device_type  in varchar2,
        p_phone_number in varchar2,
        p_verified     in varchar2 default 'N',
        p_skip_modal   in varchar2,
        p_email        in varchar2
    );

end pc_user_security_pkg;
/


-- sqlcl_snapshot {"hash":"34f780aa4a62854f84c64f3ee6c8c2c16f9e2074","type":"PACKAGE_SPEC","name":"PC_USER_SECURITY_PKG","schemaName":"SAMQA","sxml":""}