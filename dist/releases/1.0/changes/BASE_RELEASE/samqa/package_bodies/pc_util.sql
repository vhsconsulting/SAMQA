-- liquibase formatted sql
-- changeset SAMQA:1754374099541 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_util.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_util.sql:null:9424cff1fdf7cf436a183e13b77e260d106cb56a:create

create or replace package body samqa.pc_util is

-- PL/SQL Block
    procedure inc (
        val_inout    in out number,
        increment_in in number := 1
    ) is
    begin
        val_inout := val_inout + increment_in;
    end inc;

    procedure inc (
        val_inout    in out varchar2,
        increment_in in varchar2
    ) is
    begin
        val_inout := val_inout || increment_in;
    end inc;

    function subchr (
        str_in in varchar2,
        col_in in number
    ) return varchar2 is
    begin
        return ( substr(str_in, col_in, 1) );
    end subchr;

    function iif (
        expr_in in boolean,
        val1_in in varchar2,
        val2_in in varchar2,
        val3_in in varchar2 := null
    ) return varchar2 is
    begin
        if expr_in = true then
            return ( val1_in );
        elsif expr_in = false then
            return ( val2_in );
        elsif expr_in is null then
            return ( val3_in );
        end if;
    end iif;

    function iif (
        expr_in in boolean,
        val1_in in number,
        val2_in in number,
        val3_in in number := null
    ) return number is
    begin
        if expr_in = true then
            return ( val1_in );
        elsif expr_in = false then
            return ( val2_in );
        elsif expr_in is null then
            return ( val3_in );
        end if;
    end iif;

    function iif (
        expr_in in boolean,
        val1_in in date,
        val2_in in date,
        val3_in in date := null
    ) return date is
    begin
        if expr_in = true then
            return ( val1_in );
        elsif expr_in = false then
            return ( val2_in );
        elsif expr_in is null then
            return ( val3_in );
        end if;
    end iif;

    function iif (
        expr_in in boolean,
        val1_in in boolean,
        val2_in in boolean,
        val3_in in boolean := null
    ) return boolean is
    begin
        if expr_in = true then
            return ( val1_in );
        elsif expr_in = false then
            return ( val2_in );
        elsif expr_in is null then
            return ( val3_in );
        end if;
    end iif;

    function bool2char (
        bool_in in boolean
    ) return varchar2 is
    begin
        if bool_in = true then
            return ( true_c );
        elsif bool_in = false then
            return ( false_c );
        else
            return ( null );
        end if;
    end bool2char;

    function char2bool (
        char_in in varchar2
    ) return boolean is
    begin
        if char_in = true_c then
            return ( true );
        elsif char_in = false_c then
            return ( false );
        else
            return ( null );
        end if;
    end char2bool;

    function bool2num (
        bool_in in boolean
    ) return number is
    begin
        if bool_in = true then
            return ( ntrue_c );
        elsif bool_in = false then
            return ( nfalse_c );
        else
            return ( null );
        end if;
    end bool2num;

    function num2bool (
        num_in in number
    ) return boolean is
    begin
        if num_in = ntrue_c then
            return ( true );
        elsif num_in = nfalse_c then
            return ( false );
        else
            return ( null );
        end if;
    end num2bool;

    function compare (
        arg1_in in number,
        arg2_in in number
    ) return boolean is
    begin
        return ( ( arg1_in = arg2_in )
        or (
            arg1_in is null
            and arg2_in is null
        ) );
    end compare;

    function compare (
        arg1_in in varchar2,
        arg2_in in varchar2
    ) return boolean is
    begin
        return ( ( arg1_in = arg2_in )
        or (
            arg1_in is null
            and arg2_in is null
        ) );
    end compare;

    function compare (
        arg1_in in date,
        arg2_in in date
    ) return boolean is
    begin
        return ( ( arg1_in = arg2_in )
        or (
            arg1_in is null
            and arg2_in is null
        ) );
    end compare;

    function is_role (
        role_in varchar2
    ) return boolean is
        cursor c1 is
        select
            role
        from
            session_roles
        where
            role = role_in;

        ret_v boolean;
        rec_v c1%rowtype;
    begin
        open c1;
        fetch c1 into rec_v;
        ret_v := c1%found;
        close c1;
        return ret_v;
    end;

end pc_util;
/

