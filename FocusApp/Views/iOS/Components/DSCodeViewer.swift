// LegacyDSCodeViewer.swift
// FocusApp — Dark code viewer with syntax highlighting
// Spec: FIGMA_SETUP_GUIDE.md §3.22

import SwiftUI

struct LegacyDSCodeViewer: View {
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
                    .font(LegacyDSTypography.captionStrong)
                    .foregroundColor(LegacyDSColor.gray400)

                Spacer()

                HStack(spacing: DSLayout.spacing(.space4)) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("Read-only")
                        .font(LegacyDSTypography.caption)
                }
                .foregroundColor(LegacyDSColor.gray400)
            }
            .padding(DSLayout.spacing(.space12))

            Divider()
                .background(LegacyDSColor.gray700)

            // Code area
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    // Line numbers
                    VStack(alignment: .trailing, spacing: 0) {
                        let lines = code.components(separatedBy: "\n")
                        ForEach(0..<lines.count, id: \.self) { i in
                            Text("\(i + 1)")
                                .font(LegacyDSTypography.codeMicro)
                                .foregroundColor(LegacyDSColor.gray500)
                                .frame(width: 32, alignment: .trailing)
                                .frame(height: 18)
                        }
                    }
                    .padding(.leading, DSLayout.spacing(.space8))

                    // Code text
                    VStack(alignment: .leading, spacing: 0) {
                        let lines = code.components(separatedBy: "\n")
                        ForEach(0..<lines.count, id: \.self) { i in
                            Text(lines[i])
                                .font(LegacyDSTypography.code)
                                .foregroundColor(LegacyDSColor.gray300)
                                .frame(height: 18, alignment: .leading)
                        }
                    }
                    .padding(.leading, DSLayout.spacing(.space12))
                }
            }
            .padding(.vertical, DSLayout.spacing(.space12))
        }
        .background(LegacyDSColor.gray800)
        .cornerRadius(LegacyDSRadius.medium)
    }
}

#Preview {
    LegacyDSCodeViewer()
        .padding()
}
