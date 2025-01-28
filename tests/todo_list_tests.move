#[test_only]
module todo_list::todo_list_tests;
use todo_list::todo_list::{Self, TodoList};
use sui::test_scenario;
use std::string;

const ENotImplemented: u64 = 0;
const E: u64 = 1;

#[test]
fun test_todo_list() {
    let owner = @0xA;

    // Transaction: create todo list
    let mut scenario = test_scenario::begin(owner);
    {
        let todo_list = todo_list::new(scenario.ctx());
        assert!(todo_list.length() == 0, E);
        transfer::public_transfer(todo_list, owner)
    };

    // Transaction: add todo
    scenario.next_tx(owner);
    {
        let mut todo_list = test_scenario::take_from_sender<TodoList>(&scenario);
        let todo = string::utf8(b"a todo");
        todo_list.add(todo);
        assert!(todo_list.length() == 1, E);
        scenario.return_to_sender(todo_list) // without this, TodoList would have to be droppable
    };

    // Transaction: read todo list
    scenario.next_tx(owner);
    {
        let todo_list = test_scenario::take_from_sender<TodoList>(&scenario);
        assert!(todo_list.length() == 1, E);
        scenario.return_to_sender(todo_list)
    };

    // Transaction: delete todo list
    scenario.next_tx(owner);
    {
        let todo_list = test_scenario::take_from_sender<TodoList>(&scenario);
        todo_list.delete()
    };

    scenario.end();
}

#[test]
fun test_no_test() {
    // pass
}

#[test, expected_failure(abort_code = ::todo_list::todo_list_tests::ENotImplemented)]
fun test_fail() {
    abort ENotImplemented
}
