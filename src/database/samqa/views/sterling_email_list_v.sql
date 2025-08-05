create or replace force editionable view samqa.sterling_email_list_v (
    email
) as
    select
        'shavee.kapoor@sterlinghsa.com' email
    from
        dual
    union
    select
        'nancy.brumfield@sterlinghsa.com'
    from
        dual
    union
    select
        'duarte.batista@sterlinghsa.com'
    from
        dual
    union
    select
        'vanitha.subramanyam@sterlinghsa.com'
    from
        dual
    union
    select
        'cora.tellez@sterlinghsa.com'
    from
        dual
    union
    select
        'chris.bettner@sterlinghsa.com'
    from
        dual
    union
    select
        'bhuphendra.banodhe@sterlinghsa.com'
    from
        dual;


-- sqlcl_snapshot {"hash":"5f2fc5c25c613f2f4f059dc55eaa6a6b82d52c83","type":"VIEW","name":"STERLING_EMAIL_LIST_V","schemaName":"SAMQA","sxml":""}