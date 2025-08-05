-- liquibase formatted sql
-- changeset SAMQA:1754374141343 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_util.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_util.sql:null:b30d61966047977b9d28de06dd0f9d4ea77ae68b:create

create or replace package samqa.pc_util is

/*
-- ??????????
--    ????? ???????? ?????? ???????????.
-- ???????????
--  18.01.2001 pal  - ???????? ??????
--  14.06.2001 kats  is_role
*/

    true_c constant varchar2(1) := 'T';
    false_c constant varchar2(1) := 'F';
    ntrue_c constant pls_integer := 1;
    nfalse_c constant pls_integer := 0;
    procedure inc (
        val_inout    in out number,
        increment_in in number := 1
    );

    pragma restrict_references ( inc,
    wnds,
    wnps );
    procedure inc (
        val_inout    in out varchar2,
        increment_in in varchar2
    );

    pragma restrict_references ( inc,
    wnds,
    wnps );
    function subchr (
        str_in in varchar2,
        col_in in number
    ) return varchar2;

    pragma restrict_references ( subchr,
    wnds,
    wnps );
    function iif (
        expr_in in boolean,
        val1_in in varchar2,
        val2_in in varchar2,
        val3_in in varchar2 := null
    ) return varchar2;

    pragma restrict_references ( iif,
    wnds,
    wnps );
    function iif (
        expr_in in boolean,
        val1_in in number,
        val2_in in number,
        val3_in in number := null
    ) return number;

    pragma restrict_references ( iif,
    wnds,
    wnps );
    function iif (
        expr_in in boolean,
        val1_in in date,
        val2_in in date,
        val3_in in date := null
    ) return date;

    pragma restrict_references ( iif,
    wnds,
    wnps );
    function iif (
        expr_in in boolean,
        val1_in in boolean,
        val2_in in boolean,
        val3_in in boolean := null
    ) return boolean;

    pragma restrict_references ( iif,
    wnds,
    wnps );
    function bool2char (
        bool_in in boolean
    ) return varchar2;

    pragma restrict_references ( bool2char,
    wnds,
    wnps );
    function char2bool (
        char_in in varchar2
    ) return boolean;

    pragma restrict_references ( char2bool,
    wnds,
    wnps );
    function bool2num (
        bool_in in boolean
    ) return number;

    pragma restrict_references ( bool2num,
    wnds,
    wnps );
    function num2bool (
        num_in in number
    ) return boolean;

    pragma restrict_references ( num2bool,
    wnds,
    wnps );

/*
-- ??? ????????????? ???????, ??????????? ???????? ?? ?????????? ?????????
-- ???????????. ???? ??? ????????? ?????? (NULL), ?? ????????? ??? ??? ?????????.
*/
    function compare (
        arg1_in in number,
        arg2_in in number
    ) return boolean;

    function compare (
        arg1_in in varchar2,
        arg2_in in varchar2
    ) return boolean;

    function compare (
        arg1_in in date,
        arg2_in in date
    ) return boolean;
-- TRUE, ???? ? ???????????? ???? ?????? ????
    function is_role (
        role_in varchar2
    ) return boolean;

end pc_util;
/

