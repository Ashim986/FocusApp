// DSCodeViewer.swift
// FocusApp — Dark code viewer with syntax highlighting
// Spec: FIGMA_SETUP_GUIDE.md §3.22

import SwiftUI

struct DSCodeViewer: View {
    var language: String = "TypeScript"
    var code: String = """
    function twoSum(nums: number[], target: number): number[] {
        const map = new Map<number, number>();
        for (let i = 0; i < nums.length; i++) {
            const complement = target - nums[i];
            if (map.has(complement)) {
                return [map.get(complement)!, i];
            }
            map.set(nums[i], i);
        }
        return [];
    }
    """

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(language)
                    .font(DSTypography.captionStrong)
                    .foregroundColor(DSColor.gray400)

                Spacer()

                HStack(spacing: DSSpacing.space4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("Read-only")
                        .font(DSTypography.caption)
                }
                .foregroundColor(DSColor.gray400)
            }
            .padding(DSSpacing.space12)

            Divider()
                .background(DSColor.gray700)

            // Code area
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    // Line numbers
                    VStack(alignment: .trailing, spacing: 0) {
                        let lines = code.components(separatedBy: "\n")
                        ForEach(0..<lines.count, id: \.self) { i in
                            Text("\(i + 1)")
                                .font(DSTypography.codeMicro)
                                .foregroundColor(DSColor.gray500)
                                .frame(width: 32, alignment: .trailing)
                                .frame(height: 18)
                        }
                    }
                    .padding(.leading, DSSpacing.space8)

                    // Code text
                    VStack(alignment: .leading, spacing: 0) {
                        let lines = code.components(separatedBy: "\n")
                        ForEach(0..<lines.count, id: \.self) { i in
                            Text(lines[i])
                                .font(DSTypography.code)
                                .foregroundColor(DSColor.gray300)
                                .frame(height: 18, alignment: .leading)
                        }
                    }
                    .padding(.leading, DSSpacing.space12)
                }
            }
            .padding(.vertical, DSSpacing.space12)
        }
        .background(DSColor.gray800)
        .cornerRadius(DSRadius.medium)
    }
}

#Preview {
    DSCodeViewer()
        .padding()
}
