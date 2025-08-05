-- liquibase formatted sql
-- changeset SAMQA:1754374178781 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\sterling_email_list_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/sterling_email_list_v.sql:null:5f2fc5c25c613f2f4f059dc55eaa6a6b82d52c83:create

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

