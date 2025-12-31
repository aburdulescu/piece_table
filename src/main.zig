const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    // TODO: implement a simple text file line editor using a piece table
}

test "simple test" {
    var pt = PieceTable.init("hello world");
    pt.dump_table("initial");

    pt.add("bad", 6);
    pt.dump_table("add 'bad'");

    pt.add("and goodbye!", 10);
    pt.dump_table("add 'and goodbye!'");

    // TODO: assert expected
}

const PieceTable = struct {
    buf: [1024]u8 = undefined,
    buf_len: usize = 0,

    table: [1024]Piece = undefined,
    table_len: usize = 0,

    const From = enum { original, add};

    const Piece = struct {
        from: From,
        pos: usize,
        len: usize,

        fn contains(self: Piece, pos: usize) bool {
            return self.pos <= pos and pos < (self.pos + self.len);
        }
    };

    fn dump_table(self: PieceTable, header: []const u8) void {
        std.debug.print("==== {s} ====\n", .{header});
        for (self.table[0..self.table_len]) |item| {
            std.debug.print("{}\n", .{item});
        }
    }

    pub fn init(text: []const u8) PieceTable {
        var self: PieceTable = .{};
        self.append_piece(.{
            .from = .original,
            .pos = 0,
            .len = text.len,
        });
        return self;
    }

    pub fn add(self: *PieceTable, text: []const u8, pos: usize) void {
        var target_piece: ?usize = null;
        for (self.table[0..self.table_len], 0..) |item, i| {
            if (item.contains(pos)) {
                target_piece = i;
                break;
            }
        }
        assert(target_piece != null);

        self.append_text(text);
        self.append_piece(.{
            .from = .add,
            .pos = pos,
            .len = text.len,
        });
    }

    fn append_text(self: *PieceTable, text: []const u8) void {
        @memcpy(self.buf[self.buf_len..self.buf_len+text.len], text);
        self.buf_len += text.len;
    }

    fn append_piece(self: *PieceTable, p: Piece) void {
        self.table[self.table_len] = p;
        self.table_len += 1;
    }
};
