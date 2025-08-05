-- liquibase formatted sql
-- changeset SAMQA:1754374178545 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\report_period.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/report_period.sql:null:d2e1a296c4942dfaacd635887d0c7cc93dcebf4f:create

create or replace force editionable view samqa.report_period (
    idx,
    period,
    meaning
) as
    select
        rownum     idx,
        trunc(sysdate, 'MM')
        || '#'
        || sysdate period,
        'Current Month ('
        || initcap(to_char(sysdate, 'MONTHYYYY'))
        || ')'     meaning
    from
        dual
    union
    select
        rownum + 1,
        trunc(trunc(sysdate, 'MM') - 1,
              'MM')
        || '#'
        || ( trunc(sysdate, 'MM') - 1 ),
        'Previous Month ('
        || initcap(to_char(trunc(sysdate, 'MM') - 1,
                           'MONTHYYYY'))
        || ')'
    from
        dual
    union
    select
        rn + 2,
        q_start
        || '#'
        || q_end,
        decode(rn, 1, 'First ', 2, 'Second',
               3, 'Third', 4, 'Fourth')
        || ' Quarter (Q'
        || rn
        || ' '
        || to_char(sysdate, 'YYYY')
        || ')'
    from
        (
            select
                rownum rn,
                add_months(
                    trunc(sysdate, 'yyyy'),
                    (rownum - 1) * 3
                )      q_start,
                add_months(
                    trunc(sysdate, 'yyyy'),
                    rownum * 3
                ) - 1  q_end
            from
                all_objects
            where
                rownum <= 4
        )
    union
    select
        rownum + 6,
        trunc(sysdate, 'YYYY')
        || '#'
        || sysdate,
        'Current Year (YTD '
        || to_char(sysdate, 'YYYY')
        || ')'
    from
        dual
    union
    select
        rownum + 7,
        beg
        || '#'
        || end,
        'Last Year ( '
        || mont
        || ')'
    from
        (
            select
                trunc(dt, 'MON')     beg,
                dt                   end,
                to_char(dt, 'MONTH') mont
            from
                (
                    select
                        add_months(trunc(trunc(sysdate, 'y') - 2,
                                         'yyyy') - 1,
                                   rownum) dt
                    from
                        all_objects
                    where
                        rownum <= 12
                )
        )
    union
    select
        rownum + 19,
        to_char(trunc((trunc(sysdate, 'YYYY') - 1),
                      'YYYY'))
        || '#'
        || ( trunc(sysdate, 'YYYY') - 1 ),
        'Last Year (All '
        || to_char(trunc(sysdate, 'YYYY') - 1,
                   'YYYY')
        || ')'
    from
        dual
    union
    select
        rownum + 20,
        '01-JAN-04'
        || '#'
        || sysdate,
        'All Account Activity'
    from
        dual;

