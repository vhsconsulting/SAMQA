-- liquibase formatted sql
-- changeset SAMQA:1754374130801 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\test_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/test_pkg.sql:null:54ed8ca277b8abf6931d8901d20f77d551f86889:create

create or replace package body samqa.test_pkg as

    function get_employee_details (
        p_employee_id in number
    ) return employee_t
        pipelined
        deterministic
    is

        l_record employee_rec;
        cursor l_cursor is
        select
            '123',
            '2333',
            'Manager',
            1000
        from
            dual
        union
        select
            '121',
            '2334',
            'Clerk',
            200
        from
            dual;

    begin
  -- Run the query using the common function
        open l_cursor;

    -- Traverse the rows in the cursor
        loop

      -- Put this row data into the record
            fetch l_cursor into
                l_record.employee_id,
                l_record.employee_number,
                l_record.job,
                l_record.salary;

      -- Check for the no more rows condition
            exit when l_cursor%notfound;

      -- Pipe the row into the result set
            pipe row ( l_record );
        end loop;

    -- Close the cursor and return to the caller
        close l_cursor;
        return;
    end get_employee_details;

end test_pkg;
/

