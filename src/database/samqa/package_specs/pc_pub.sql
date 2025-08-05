create or replace package samqa.pc_pub as



/*
  Public declarations
  13.08.2004 mal Creation
*/
    cursor pers_cur (
        p_in in number
    ) is
    select
        *
    from
        person
    where
        pers_id = p_in;

    pers_rec pers_cur%rowtype;
    cursor col_cur (
        p_in in varchar2,
        t_in in varchar2 := 'PERSON'
    ) is
    select
        data_type
    from
        cols
    where
            column_name = p_in
        and table_name = t_in;

    dummy varchar2(4000);
    date_mask1 varchar2(40) := 'mm-dd-yyyy';
    date_mask2 varchar2(40) := 'fmMonth, dd yyyy';
end pc_pub;
/


-- sqlcl_snapshot {"hash":"8ae9890ebbd2a4605d4cd45e0ef3678056d21f17","type":"PACKAGE_SPEC","name":"PC_PUB","schemaName":"SAMQA","sxml":""}