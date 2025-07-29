create or replace package body samqa.pc_group is

-- ??? ??.??????????? ?????????? ???-?? ACCOUNT-??
    function count_account (
        entrp_id_in in enterprise.entrp_id%type
    ) return number is

        cursor c1 (
            p_entrp_id enterprise.entrp_id%type
        ) is
        select
            count(1) c
        from
            account
        where
            entrp_id = p_entrp_id;

        r1 c1%rowtype;
    begin
        open c1(entrp_id_in);
        fetch c1 into r1;
        close c1;
        return r1.c;
    end count_account;
-- ??? ??.??????????? ?????????? ??. ACCOUNT-? ??? NULL, ???? ???
    function acc_id (
        entrp_id_in in enterprise.entrp_id%type
    ) return account.acc_id%type is

        cursor c1 (
            p_entrp_id enterprise.entrp_id%type
        ) is
        select
            acc_id
        from
            account
        where
            entrp_id = p_entrp_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(entrp_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.acc_id;
        else
            return null;
        end if;
    end acc_id;
-- ??? ??.??????????? ?????????? ????? ACCOUNT-?
    function acc_num (
        entrp_id_in in enterprise.entrp_id%type
    ) return account.acc_num%type is

        cursor c1 (
            p_entrp_id enterprise.entrp_id%type
        ) is
        select
            acc_num
        from
            account
        where
            entrp_id = p_entrp_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(entrp_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.acc_num;
        else
            return null;
        end if;
    end acc_num;
-- ??? ??.??????????? ?????????? ???? (?????)
    function state (
        entrp_id_in in enterprise.entrp_id%type
    ) return enterprise.state%type is

        cursor c1 (
            p_entrp_id enterprise.entrp_id%type
        ) is
        select
            state
        from
            enterprise
        where
            entrp_id = p_entrp_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(entrp_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.state;
        else
            return null;
        end if;
    end state;

end pc_group;
/


-- sqlcl_snapshot {"hash":"14bd7d6589a7cd87e97fed0e0daf55ee316eab09","type":"PACKAGE_BODY","name":"PC_GROUP","schemaName":"SAMQA","sxml":""}