const std = @import("std");
const rem = @import("rem");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    // This is the text that will be read by the parser.
    // Since the parser accepts Unicode codepoints, the text must be decoded before it can be used.
    const input = "<!doctype html><html><h1 style=bold>Your tx goes here!</h1>";
    const decoded_input = &rem.util.utf8DecodeStringComptime(input);

    // Create the DOM in which the parsed Document will be created.
    var dom = rem.Dom{ .allocator = allocator };
    defer dom.deinit();

    // Create the HTML parser.
    var parser = try rem.Parser.init(&dom, decoded_input, allocator, .report, false);
    defer parser.deinit();

    // This causes the parser to read the input and produce a Document.
    try parser.run();

    // `errors` returns the list of parse errors that were encountered while parsing.
    // Since we know that our input was well-formed HTML, we expect there to be 0 parse errors.
    const errors = parser.errors();
    std.debug.assert(errors.len == 0);

    // We can now print the resulting Document to the console.
    const stdout = std.io.getStdOut().writer();
    const document = parser.getDocument();
    try rem.util.printDocument(stdout, document, &dom, allocator);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
