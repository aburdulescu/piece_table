const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    // TODO: implement a simple text file line editor using a piece table
}

test "simple test" {
    var pt = PieceTable.init("hello world");
    pt.dump_table("initial");

    pt.add(5, " bad");
    pt.dump_table("add 'bad'");

    pt.add(15, " and goodbye!");
    pt.dump_table("add 'and goodbye!'");

    pt.add(6, "good/");
    pt.dump_table("add 'good/'");

    pt.add(0, "i say: ");
    pt.dump_table("add 'i say: '");

    // "i say: hello good/bad world and goodbye!"

    // TODO: assert expected
}

const PieceTable = struct {
    buf: [1024]u8 = undefined,
    buf_len: usize = 0,

    table: [1024]Piece = undefined,
    table_len: usize = 0,

    logical_len: usize = 0,

    const From = enum { original, add };

    const Piece = struct {
        from: From,
        pos: usize,
        len: usize,
    };

    fn dump_table(self: PieceTable, header: []const u8) void {
        std.debug.print("==== {s} ====\n", .{header});
        for (self.table[0..self.table_len]) |item| {
            std.debug.print("{}\n", .{item});
        }
    }

    pub fn init(text: []const u8) PieceTable {
        var self: PieceTable = .{
            .logical_len = text.len,
        };
        self.append_piece(.{
            .from = .original,
            .pos = 0,
            .len = text.len,
        });
        return self;
    }

    pub fn add(self: *PieceTable, cursor: usize, text: []const u8) void {
        assert(cursor <= self.logical_len);

        if (cursor != self.logical_len) {
            var target_piece: ?usize = null;
            var start: usize = 0;
            for (self.table[0..self.table_len], 0..) |item, i| {
                const end = start + item.len;
                std.debug.print("find: {d} {} [{d},{d}]\n", .{cursor, item, start, end});
                if (start <= cursor and cursor <= end) {
                    target_piece = i;
                    break;
                } else {
                    start = end;
                }
            }
            assert(target_piece != null);
            std.debug.print("target = {}\n", .{self.table[target_piece.?]});



            // TODO: insert new piece and split existing, if needed
        } else {
            self.append_piece(.{
                .from = .add,
                .pos = self.buf_len,
                .len = text.len,
            });
        }

        self.append_text(text);
        self.logical_len += text.len;
    }

    fn append_text(self: *PieceTable, text: []const u8) void {
        @memcpy(self.buf[self.buf_len .. self.buf_len + text.len], text);
        self.buf_len += text.len;
    }

    fn append_piece(self: *PieceTable, p: Piece) void {
        self.table[self.table_len] = p;
        self.table_len += 1;
    }
};
